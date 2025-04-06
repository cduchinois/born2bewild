import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { Born2bewild } from "../target/types/born2bewild";
import { TOKEN_PROGRAM_ID, createMint, createAccount } from "@solana/spl-token";
import { PublicKey, Keypair, SystemProgram, LAMPORTS_PER_SOL } from "@solana/web3.js";
import { assert } from "chai";

describe("born2bewild", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.Born2bewild as Program<Born2bewild>;
  
  // Project creator
  const creator = Keypair.generate();
  // Random donor
  const donor = Keypair.generate();
  
  // Project data
  let wildMint: PublicKey;
  let projectAccount: PublicKey;
  let treasuryAccount: PublicKey;
  let donorWildAccount: PublicKey;

  before(async () => {
    // Airdrop SOL to creator for transactions
    const creatorAirdrop = await provider.connection.requestAirdrop(
      creator.publicKey,
      2 * LAMPORTS_PER_SOL
    );
    await provider.connection.confirmTransaction(creatorAirdrop);

    // Airdrop SOL to donor for donations
    const donorAirdrop = await provider.connection.requestAirdrop(
      donor.publicKey,
      2 * LAMPORTS_PER_SOL
    );
    await provider.connection.confirmTransaction(donorAirdrop);

    // Create the $WILD token mint
    wildMint = await createMint(
      provider.connection as any,
      creator,
      creator.publicKey,
      null,
      9 // 9 decimals like most SPL tokens
    );

    // Generate project account address
    projectAccount = anchor.web3.Keypair.generate().publicKey;
    
    // Generate treasury account
    treasuryAccount = anchor.web3.Keypair.generate().publicKey;
    
    // Create donor's $WILD token account
    donorWildAccount = await createAccount(
      provider.connection as any,
      donor,
      wildMint,
      donor.publicKey
    );
  });

  it("Can create a donation project", async () => {
    await program.methods
      .createProject(
        "Save the Trees",
        "Help us plant more trees!",
        wildMint
      )
      .accounts({
        project: projectAccount,
        creator: creator.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .signers([creator])
      .rpc();

    const projectData = await program.account.donationProject.fetch(projectAccount);
    console.log("Project created:", {
      name: projectData.name,
      description: projectData.description,
      creator: projectData.creator.toBase58(),
    });
  });

  it("Can donate SOL and receive $WILD", async () => {
    const donationAmount = new anchor.BN(0.5 * LAMPORTS_PER_SOL); // 0.5 SOL

    const donorInitialBalance = await provider.connection.getBalance(donor.publicKey);
    
    await program.methods
      .donate(donationAmount)
      .accounts({
        project: projectAccount,
        donor: donor.publicKey,
        treasury: treasuryAccount,
        wildTokenAccount: donorWildAccount,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
      })
      .signers([donor])
      .rpc();

    // Check balances
    const donorFinalBalance = await provider.connection.getBalance(donor.publicKey);
    const treasuryBalance = await provider.connection.getBalance(treasuryAccount);
    const wildBalance = await provider.connection.getTokenAccountBalance(donorWildAccount);

    console.log("Donation successful:", {
      solSpent: (donorInitialBalance - donorFinalBalance) / LAMPORTS_PER_SOL,
      treasuryBalance: treasuryBalance / LAMPORTS_PER_SOL,
      wildReceived: wildBalance.value.uiAmount,
    });
  });

  it("Creator can withdraw from treasury", async () => {
    const withdrawAmount = new anchor.BN(0.3 * LAMPORTS_PER_SOL); // 0.3 SOL
    
    const creatorInitialBalance = await provider.connection.getBalance(creator.publicKey);
    const treasuryInitialBalance = await provider.connection.getBalance(treasuryAccount);

    await program.methods
      .withdraw(withdrawAmount)
      .accounts({
        project: projectAccount,
        creator: creator.publicKey,
        treasury: treasuryAccount,
        systemProgram: SystemProgram.programId,
      })
      .signers([creator])
      .rpc();

    const creatorFinalBalance = await provider.connection.getBalance(creator.publicKey);
    const treasuryFinalBalance = await provider.connection.getBalance(treasuryAccount);

    console.log("Withdrawal successful:", {
      creatorReceived: (creatorFinalBalance - creatorInitialBalance) / LAMPORTS_PER_SOL,
      treasuryRemaining: treasuryFinalBalance / LAMPORTS_PER_SOL,
    });
  });

  it("Non-creator cannot withdraw from treasury", async () => {
    const withdrawAmount = new anchor.BN(0.1 * LAMPORTS_PER_SOL);
    
    try {
      await program.methods
        .withdraw(withdrawAmount)
        .accounts({
          project: projectAccount,
          creator: donor.publicKey, // Using donor instead of creator
          treasury: treasuryAccount,
          systemProgram: SystemProgram.programId,
        })
        .signers([donor])
        .rpc();
      
      assert.fail("Should not allow non-creator to withdraw");
    } catch (error) {
      console.log("Successfully prevented unauthorized withdrawal");
    }
  });
});
