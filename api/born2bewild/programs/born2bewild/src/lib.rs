use anchor_lang::prelude::*;
declare_id!("HhkSJ9aaJhHSkPfxDk29Mrzx2SNkf8Z6Sm8ZbQRMBKTq");

pub mod state;
pub mod contexts;
pub mod errors;

pub use contexts::*;
pub use errors::*;

#[program]
pub mod born2bewild {
    use super::*;

    pub fn init(ctx: Context<Initialize>, name: String) -> Result<()> {
        ctx.accounts.init(name, &ctx.bumps)?;
        
        // Emit token creation event
        emit!(WildTokenCreated {
            platform: ctx.accounts.born2bewild.key(),
            mint: ctx.accounts.wild_token_mint.key(),
            decimals: 9,
            timestamp: Clock::get()?.unix_timestamp,
        });

        Ok(())
    }

    pub fn create_donation_project(ctx: Context<CreateProject>, name: String, description: String, location: String, target_amount: u64, target_animal: String) -> Result<()> {
        ctx.accounts.create_project(name, description, location, target_amount, target_animal, &ctx.bumps)
    }

    pub fn donate(ctx: Context<Donate>, project_name: String, amount: u64) -> Result<()> {
        ctx.accounts.donate(amount)?;

        // Emit token minting event
        emit!(WildTokenMinted {
            recipient: ctx.accounts.donor.key(),
            amount: amount * 100,  // 1 SOL = 100 WILD
            donation_amount: amount,
            project: ctx.accounts.project.key(),
            timestamp: Clock::get()?.unix_timestamp,
        });

        Ok(())
    }

    pub fn withdraw(ctx: Context<Withdraw>, project_name: String, amount: u64) -> Result<()> {
        ctx.accounts.withdraw(amount)
    }
}

#[event]
pub struct WildTokenCreated {
    pub platform: Pubkey,
    pub mint: Pubkey,
    pub decimals: u8,
    pub timestamp: i64,
}

#[event]
pub struct WildTokenMinted {
    pub recipient: Pubkey,
    pub amount: u64,
    pub donation_amount: u64,
    pub project: Pubkey,
    pub timestamp: i64,
}
