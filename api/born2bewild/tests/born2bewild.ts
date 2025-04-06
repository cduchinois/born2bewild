import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { Born2bewild } from "../target/types/born2bewild";
import { Keypair, PublicKey, SystemProgram, LAMPORTS_PER_SOL } from "@solana/web3.js";
import { TOKEN_PROGRAM_ID, getAssociatedTokenAddress, createAssociatedTokenAccountInstruction } from "@solana/spl-token";
import { assert } from "chai";
import { Transaction } from "@solana/web3.js";

describe("born2bewild", () => {
  // Configure the client to use the local cluster
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.Born2bewild as Program<Born2bewild>;
  const admin = provider.wallet;

  // Platform PDAs
  let born2bewildPDA: PublicKey;
  let wildTokenMint: PublicKey;

  // Project data
  let projectPDA: PublicKey;
  let treasuryPDA: PublicKey;
  
  // Test accounts
  let donor: Keypair;
  let projectCreator: Keypair;

  const PLATFORM_NAME = "Born2BeWild v1";
  const PROJECT_NAME = "Save the Tigers";
  const PROJECT_DESC = "Help us protect tigers in Asia";
  const PROJECT_LOCATION = "Asia";
  const PROJECT_TARGET_AMOUNT = new anchor.BN(10 * LAMPORTS_PER_SOL); // 10 SOL
  const PROJECT_TARGET_ANIMAL = "Tiger";

  before(async () => {
    // Generate test accounts
    donor = anchor.web3.Keypair.generate();
    projectCreator = anchor.web3.Keypair.generate();

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
    [wildTokenMint] = await PublicKey.findProgramAddressSync(
      [Buffer.from("wild_token"), Buffer.from(PLATFORM_NAME)],
      program.programId
    );
    console.log("WILD Token Mint:", wildTokenMint.toBase58());

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
        wildTokenMint: wildTokenMint,
        systemProgram: SystemProgram.programId,
        tokenProgram: TOKEN_PROGRAM_ID,
        rent: anchor.web3.SYSVAR_RENT_PUBKEY,
      })
      .rpc();
    
    console.log("Platform initialized:", tx);

    // Verify platform initialization
    const platformConfig = await program.account.config.fetch(born2bewildPDA);
    assert.equal(platformConfig.admin.toBase58(), admin.publicKey.toBase58());
    assert.equal(platformConfig.name, PLATFORM_NAME);
    assert.ok(platformConfig.wildTokenMint);
  });

  /*it("Creates a donation project", async () => {
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
      wildTokenMint,
      donor.publicKey
    );

    // Create the associated token account if it doesn't exist
    const createAtaIx = await createAssociatedTokenAccountInstruction(
      donor.publicKey,
      donorWildAccount,
      donor.publicKey,
      wildTokenMint
    );
    const tx = await provider.sendAndConfirm(new Transaction().add(createAtaIx), [donor]);
    console.log("Created donor's token account:", tx);

    // Record initial balances
    const donorInitialBalance = await provider.connection.getBalance(donor.publicKey);
    const treasuryInitialBalance = await provider.connection.getBalance(treasuryPDA);
    
    const donationAmount = new anchor.BN(0.5 * LAMPORTS_PER_SOL); // 0.5 SOL

    const tx2 = await program.methods
      .donate(PROJECT_NAME, donationAmount)
      .accounts({
        donor: donor.publicKey,
        wildTokenMint: wildTokenMint,
        wildTokenAccount: donorWildAccount,
        project: projectPDA,
        treasury: treasuryPDA,
        platform: born2bewildPDA,
      })
      .signers([donor])
      .rpc();

    console.log("Donation processed:", tx2);

    // Verify balances after donation
    const donorFinalBalance = await provider.connection.getBalance(donor.publicKey);
    const treasuryFinalBalance = await provider.connection.getBalance(treasuryPDA);
    const wildTokenBalance = await provider.connection.getTokenAccountBalance(donorWildAccount);

    // Verify SOL transfer
    assert.equal(
      donorInitialBalance - donorFinalBalance,
      donationAmount.toNumber(),
      "Incorrect SOL deduction from donor"
    );
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
        recipient: projectCreator.publicKey
      })
      .signers([projectCreator])
      .rpc();

    console.log("Withdrawal processed:", tx);

    // Verify balances after withdrawal
    const creatorFinalBalance = await provider.connection.getBalance(projectCreator.publicKey);
    const treasuryFinalBalance = await provider.connection.getBalance(treasuryPDA);

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
  });*/
});
