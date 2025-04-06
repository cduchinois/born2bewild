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
        ctx.accounts.init(name, &ctx.bumps)
    }

    pub fn create_donation_project(ctx: Context<CreateProject>, name: String, description: String, location: String, target_amount: u64, target_animal: String) -> Result<()> {
        ctx.accounts.create_project(name, description, location, target_amount, target_animal, &ctx.bumps)
    }

    pub fn donate(ctx: Context<Donate>, project_name: String, amount: u64) -> Result<()> {
        ctx.accounts.donate(amount)
    }

    pub fn withdraw(ctx: Context<Withdraw>, project_name: String, amount: u64) -> Result<()> {
        ctx.accounts.withdraw(amount)
    }
}
