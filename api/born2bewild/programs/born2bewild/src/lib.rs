use anchor_lang::prelude::*;
use anchor_lang::system_program::{self, Transfer};
use anchor_spl::token::{self, Mint, Token, TokenAccount, MintTo};

declare_id!("HhkSJ9aaJhHSkPfxDk29Mrzx2SNkf8Z6Sm8ZbQRMBKTq");

#[program]
pub mod born2bewild {
    use super::*;

    // Initialize a new donation project
    pub fn create_project(
        ctx: Context<CreateProject>,
        name: String,
        description: String,
        wild_token_mint: Pubkey,
    ) -> Result<()> {
        let project = &mut ctx.accounts.project;
        let creator = &ctx.accounts.creator;

        project.name = name;
        project.description = description;
        project.creator = creator.key();
        project.wild_token_mint = wild_token_mint;
        project.total_donations = 0;
        project.treasury_bump = ctx.bumps.treasury;
        
        Ok(())
    }

    // Donate SOL to receive $WILD tokens
    pub fn donate(ctx: Context<Donate>, amount: u64) -> Result<()> {
        let project = &mut ctx.accounts.project;
        
        // Transfer SOL from donor to treasury
        system_program::transfer(
            CpiContext::new(
                ctx.accounts.system_program.to_account_info(),
                Transfer {
                    from: ctx.accounts.donor.to_account_info(),
                    to: ctx.accounts.treasury.to_account_info(),
                },
            ),
            amount,
        )?;

        // Mint $WILD tokens to donor's token account
        // For simplicity, let's say 1 SOL = 100 $WILD
        let wild_amount = amount * 100;
        
        token::mint_to(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                MintTo {
                    mint: ctx.accounts.wild_token_mint.to_account_info(),
                    to: ctx.accounts.wild_token_account.to_account_info(),
                    authority: ctx.accounts.creator.to_account_info(),
                },
            ),
            wild_amount,
        )?;

        project.total_donations += amount;
        
        Ok(())
    }

    // Withdraw SOL from treasury (only project creator)
    pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
        let project = &ctx.accounts.project;
        let treasury = &ctx.accounts.treasury;
        
        require!(
            ctx.accounts.creator.key() == project.creator,
            DonationError::UnauthorizedWithdrawal
        );

        require!(
            treasury.lamports() >= amount,
            DonationError::InsufficientFunds
        );

        **treasury.try_borrow_mut_lamports()? -= amount;
        **ctx.accounts.creator.try_borrow_mut_lamports()? += amount;
        
        Ok(())
    }

    // Function to get balance of a user (donor)
    pub fn balance_of(ctx: Context<BalanceOf>) -> Result<u64> {
        Ok(ctx.accounts.token_account.amount)
    }

    // Function to get the total donation balance in the contract
    pub fn total_balance(ctx: Context<TotalBalance>) -> Result<u64> {
        Ok(ctx.accounts.token_account.amount)
    }
}

// Define the context structures

#[derive(Accounts)]
#[instruction(name: String, description: String, wild_token_mint: Pubkey)]
pub struct CreateProject<'info> {
    #[account(
        init,
        payer = creator,
        space = 8 + 32 + 32 + 200 + 8 + 32 + 1, // discriminator + creator + treasury + name/desc + donations + mint + bump
    )]
    pub project: Account<'info, DonationProject>,
    #[account(mut)]
    pub creator: Signer<'info>,
    #[account(
        seeds = [b"treasury", project.key().as_ref()],
        bump
    )]
    pub treasury: SystemAccount<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Donate<'info> {
    #[account(mut)]
    pub project: Account<'info, DonationProject>,
    #[account(mut)]
    pub donor: Signer<'info>,
    #[account(
        mut,
        seeds = [b"treasury", project.key().as_ref()],
        bump = project.treasury_bump
    )]
    pub treasury: SystemAccount<'info>,
    #[account(
        mut,
        constraint = wild_token_mint.key() == project.wild_token_mint
    )]
    pub wild_token_mint: Account<'info, Mint>,
    #[account(mut)]
    pub wild_token_account: Account<'info, TokenAccount>,
    /// CHECK: This is the project creator who has mint authority
    #[account(
        mut,
        constraint = creator.key() == project.creator
    )]
    pub creator: AccountInfo<'info>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Withdraw<'info> {
    pub project: Account<'info, DonationProject>,
    #[account(mut)]
    pub creator: Signer<'info>,
    #[account(
        mut,
        seeds = [b"treasury", project.key().as_ref()],
        bump = project.treasury_bump
    )]
    pub treasury: SystemAccount<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct BalanceOf<'info> {
    pub donor: Signer<'info>,
    pub token_account: Account<'info, TokenAccount>,
}

#[derive(Accounts)]
pub struct TotalBalance<'info> {
    pub token_account: Account<'info, TokenAccount>,
}

#[account]
pub struct DonationProject {
    pub creator: Pubkey,
    pub name: String,
    pub description: String,
    pub wild_token_mint: Pubkey,
    pub total_donations: u64,
    pub treasury_bump: u8,
}

#[error_code]
pub enum DonationError {
    #[msg("Only the project creator can withdraw funds")]
    UnauthorizedWithdrawal,
    #[msg("Insufficient funds in treasury")]
    InsufficientFunds,
}
