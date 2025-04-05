use anchor_lang::prelude::*;
use spl_token::{self, state::Account as TokenAccount};

declare_id!("Fg6PaFpoGXkYsdTBaGrzJ7nxwGPaxshTgcSJEjFFoZ64");

#[program]
pub mod donation_program {
    use super::*;

    // Deposit function to deposit $Wild token to the contract
    pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
        let donor_account = &mut ctx.accounts.donor;
        let donation_account = &mut ctx.accounts.donation_account;

        // Transfer the tokens from the donor to the contract
        let cpi_accounts = spl_token::instruction::Transfer {
            from: donor_account.to_account_info(),
            to: donation_account.to_account_info(),
            authority: donor_account.to_account_info(),
        };
        
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        
        spl_token::cpi::transfer(cpi_ctx, amount)?;
        
        Ok(())
    }

    // Withdraw function to withdraw tokens from the contract
    pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
        let donor_account = &mut ctx.accounts.donor;
        let donation_account = &mut ctx.accounts.donation_account;

        // Transfer tokens from the contract to the donor
        let cpi_accounts = spl_token::instruction::Transfer {
            from: donation_account.to_account_info(),
            to: donor_account.to_account_info(),
            authority: donation_account.to_account_info(),
        };

        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);

        spl_token::cpi::transfer(cpi_ctx, amount)?;
        
        Ok(())
    }

    // Function to get balance of a user (donor)
    pub fn balance_of(ctx: Context<BalanceOf>) -> Result<u64> {
        let donor_account = &ctx.accounts.donor;
        
        let token_account_info = &ctx.accounts.token_account;
        let token_account = TokenAccount::try_from(token_account_info)?;
        
        Ok(token_account.amount)
    }

    // Function to get the total donation balance in the contract
    pub fn total_balance(ctx: Context<TotalBalance>) -> Result<u64> {
        let donation_account = &ctx.accounts.donation_account;
        
        let token_account_info = &ctx.accounts.token_account;
        let token_account = TokenAccount::try_from(token_account_info)?;
        
        Ok(token_account.amount)
    }
}

// Define the context structures

#[derive(Accounts)]
pub struct Deposit<'info> {
    #[account(mut)]
    pub donor: Signer<'info>,  // The donor who is making the deposit
    #[account(mut)]
    pub donation_account: Account<'info, TokenAccount>, // The account receiving the donations
    pub token_program: Program<'info, spl_token::Token>,  // SPL Token Program
}

#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut)]
    pub donor: Signer<'info>,  // The donor who is making the withdrawal
    #[account(mut)]
    pub donation_account: Account<'info, TokenAccount>,  // The account from which tokens are withdrawn
    pub token_program: Program<'info, spl_token::Token>,  // SPL Token Program
}

#[derive(Accounts)]
pub struct BalanceOf<'info> {
    pub donor: Signer<'info>,  // The account whose balance is being queried
    pub token_account: Account<'info, TokenAccount>,  // The SPL token account
}

#[derive(Accounts)]
pub struct TotalBalance<'info> {
    pub donation_account: Account<'info, TokenAccount>,  // The contract's donation account
    pub token_account: Account<'info, TokenAccount>,  // The SPL token account
}
