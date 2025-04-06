import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { Born2bewild } from "../target/types/born2bewild";
import { Keypair, PublicKey, SystemProgram, LAMPORTS_PER_SOL } from "@solana/web3.js";
import { 
  TOKEN_PROGRAM_ID, 
  ASSOCIATED_TOKEN_PROGRAM_ID,
  getAssociatedTokenAddress, 
} from "@solana/spl-token";
import { assert } from "chai";
import { Transaction } from "@solana/web3.js";

// Token Interface Program ID (different from regular Token Program)
const TOKEN_INTERFACE_PROGRAM_ID = new PublicKey("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA");

describe("born2bewild", () => {
  // Configure the client to use the local cluster
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.Born2bewild as Program<Born2bewild>;
  const admin = provider.wallet;

  // Platform PDAs
  let born2bewildPDA: PublicKey;
  //let wildTokenMint: PublicKey;

  // Project data
  let projectPDA: PublicKey;
  let treasuryPDA: PublicKey;
  
  // Test accounts
  let donor: Keypair;
  let projectCreator: Keypair;
  let wildTokenMint2: Keypair;

  const timestamp = Date.now();
  const PLATFORM_NAME = "Born2BeWild v" + timestamp;
  const PROJECT_NAME = "Save the Tigers " + timestamp;
  const PROJECT_DESC = "Help us protect tigers in Asia";
  const PROJECT_LOCATION = "Asia";
  const PROJECT_TARGET_AMOUNT = new anchor.BN(10 * LAMPORTS_PER_SOL); // 10 SOL
  const PROJECT_TARGET_ANIMAL = "Tiger";

  before(async () => {
    // Generate test accounts
    donor = anchor.web3.Keypair.generate();
    projectCreator = anchor.web3.Keypair.generate();
    wildTokenMint2 = anchor.web3.Keypair.generate(); //fromSecretKey(Uint8Array.from([45, 94, 64, 60, 41, 8, 198, 251, 2, 254, 209, 95, 160, 176, 176, 109, 92, 133, 103, 70, 174, 105, 46, 120, 144, 210, 82, 118, 226, 145, 96, 243, 60, 43, 15, 133, 241, 254, 239, 101, 106, 184, 179, 29, 51, 96, 31, 232, 151, 201, 238, 195, 177, 62, 56, 55, 132, 28, 38, 43, 230, 180, 52, 105]));

    // Airdrop SOL to test accounts
    await provider.connection.confirmTransaction(
      await provider.connection.requestAirdrop(donor.publicKey, 2 * LAMPORTS_PER_SOL)
    );
    await provider.connection.confirmTransaction(
      await provider.connection.requestAirdrop(projectCreator.publicKey, 2 * LAMPORTS_PER_SOL)
    );

    // Derive platform PDA
    [born2bewildPDA] = await PublicKey.findProgramAddressSync(
      [Buffer.from("born2bewild"), Buffer.from(PLATFORM_NAME)],
      program.programId
    );
    console.log("Platform PDA:", born2bewildPDA.toBase58());

    // Derive WILD token mint PDA
    //[wildTokenMint] = await PublicKey.findProgramAddressSync(
    //  [Buffer.from("wild_token"), Buffer.from(PLATFORM_NAME)],
    //  program.programId
    //);
    //console.log("WILD Token Mint:", wildTokenMint.toBase58());

    // Derive project PDAs
    [projectPDA] = await PublicKey.findProgramAddressSync(
      [Buffer.from("project"), Buffer.from(PROJECT_NAME)],
      program.programId
    );
    console.log("Project PDA:", projectPDA.toBase58());

    [treasuryPDA] = await PublicKey.findProgramAddressSync(
      [Buffer.from("treasury"), projectPDA.toBuffer()],
      program.programId
    );
    console.log("Treasury PDA:", treasuryPDA.toBase58());
  });

  it("Initializes the platform with WILD token", async () => {
    const tx = await program.methods
      .init(PLATFORM_NAME)
      .accounts({
        admin: admin.publicKey,
        born2bewild: born2bewildPDA,
        wildTokenMint: wildTokenMint2.publicKey,
        systemProgram: SystemProgram.programId,
        tokenProgram: TOKEN_PROGRAM_ID,
        rent: anchor.web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([wildTokenMint2])
      .rpc();
    
    console.log("Platform initialized:", tx);

    // Verify platform initialization
    const platformConfig = await program.account.config.fetch(born2bewildPDA);
    assert.equal(platformConfig.admin.toBase58(), admin.publicKey.toBase58());
    assert.equal(platformConfig.name, PLATFORM_NAME);
    assert.ok(platformConfig.wildTokenMint);
  });

  it("Creates a donation project", async () => {
    const tx = await program.methods
      .createDonationProject(
        PROJECT_NAME,
        PROJECT_DESC,
        PROJECT_LOCATION,
        PROJECT_TARGET_AMOUNT,
        PROJECT_TARGET_ANIMAL
      )
      .accounts({
        creator: projectCreator.publicKey,
        platform: born2bewildPDA,
      })
      .signers([projectCreator])
      .rpc();

    console.log("Project created:", tx);

    // Verify project creation
    const projectData = await program.account.donationProject.fetch(projectPDA);
    assert.equal(projectData.name, PROJECT_NAME);
    assert.equal(projectData.description, PROJECT_DESC);
    assert.equal(projectData.location, PROJECT_LOCATION);
    assert.equal(projectData.targetAmount.toString(), PROJECT_TARGET_AMOUNT.toString());
    assert.equal(projectData.targetAnimal, PROJECT_TARGET_ANIMAL);
    assert.equal(projectData.creator.toBase58(), projectCreator.publicKey.toBase58());
    assert.equal(projectData.totalDonation.toString(), "0");
  });

  it("Allows donations and mints WILD tokens", async () => {
    // Get the donor's WILD token account
    const donorWildAccount = await getAssociatedTokenAddress(
      wildTokenMint2.publicKey,
      donor.publicKey
    );

    // Record initial balances
    const donorInitialBalance = await provider.connection.getBalance(donor.publicKey);
    const treasuryInitialBalance = await provider.connection.getBalance(treasuryPDA);
    
    const donationAmount = new anchor.BN(0.5 * LAMPORTS_PER_SOL); // 0.5 SOL

    const tx = await program.methods
      .donate(PROJECT_NAME, donationAmount)
      .accounts({
        donor: donor.publicKey,
        platform: born2bewildPDA,
        wildTokenMint: wildTokenMint2.publicKey,
        wildTokenAccount: donorWildAccount,
        project: projectPDA,
        treasury: treasuryPDA,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
        associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
        rent: anchor.web3.SYSVAR_RENT_PUBKEY,
      })
      .signers([donor])
      .rpc();

    console.log("Donation processed:", tx);

    // Verify balances after donation
    const donorFinalBalance = await provider.connection.getBalance(donor.publicKey);
    const treasuryFinalBalance = await provider.connection.getBalance(treasuryPDA);
    const wildTokenBalance = await provider.connection.getTokenAccountBalance(donorWildAccount);

    // Get minimum rent for token account
    const rentExemptBalance = await provider.connection.getMinimumBalanceForRentExemption(165); // Size of token account

    // Verify SOL transfer (donation amount + rent for token account)
    assert.equal(
      donorInitialBalance - donorFinalBalance,
      donationAmount.toNumber() + rentExemptBalance,
      "Incorrect SOL deduction from donor"
    );
    
    // Verify treasury only receives donation amount
    assert.equal(
      treasuryFinalBalance - treasuryInitialBalance,
      donationAmount.toNumber(),
      "Incorrect SOL addition to treasury"
    );

    // Verify WILD token minting (1 SOL = 100 WILD)
    assert.equal(
      wildTokenBalance.value.uiAmount,
      (donationAmount.toNumber() / LAMPORTS_PER_SOL) * 100,
      "Incorrect WILD tokens minted"
    );

    // Verify project total donations updated
    const projectData = await program.account.donationProject.fetch(projectPDA);
    assert.equal(
      projectData.totalDonation.toString(),
      donationAmount.toString(),
      "Project total donations not updated correctly"
    );
  });

  it("Allows project creator to withdraw funds", async () => {
    const withdrawAmount = new anchor.BN(0.1 * LAMPORTS_PER_SOL); // 0.1 SOL
    const creatorInitialBalance = await provider.connection.getBalance(projectCreator.publicKey);
    const treasuryInitialBalance = await provider.connection.getBalance(treasuryPDA);

    const tx = await program.methods
      .withdraw(PROJECT_NAME, withdrawAmount)
      .accounts({
        project: projectPDA,
        treasury: treasuryPDA,
        platform: born2bewildPDA,
        recipient: projectCreator.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .signers([projectCreator])
      .rpc();

    console.log("Withdrawal processed:", tx);

    // Verify balances after withdrawal
    const creatorFinalBalance = await provider.connection.getBalance(projectCreator.publicKey);
    const treasuryFinalBalance = await provider.connection.getBalance(treasuryPDA);

    console.log("Creator final balance:", creatorFinalBalance);
    console.log("Treasury final balance:", treasuryFinalBalance);

    // Verify SOL transfer
    assert.equal(
      creatorFinalBalance - creatorInitialBalance,
      withdrawAmount.toNumber(),
      "Incorrect SOL addition to creator"
    );
    assert.equal(
      treasuryInitialBalance - treasuryFinalBalance,
      withdrawAmount.toNumber(),
      "Incorrect SOL deduction from treasury"
    );

    // Verify project total donations updated
    const projectData = await program.account.donationProject.fetch(projectPDA);
    assert.equal(
      projectData.totalDonation.toString(),
      new anchor.BN(0.4 * LAMPORTS_PER_SOL).toString(), // 0.5 - 0.1 SOL
      "Project total donations not updated correctly after withdrawal"
    );
  });
});
