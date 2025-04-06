//init born2bewild plateform
use anchor_lang::prelude::*;
use anchor_spl::token::{Token, Mint};

use crate::state::Config;
use crate::errors::ConfigError;

#[derive(Accounts)]
#[instruction(name: String)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub admin: Signer<'info>,

    #[account(
        init,
        payer = admin,
        space = Config::INIT_SPACE,
        seeds = [b"born2bewild", name.as_bytes()],
        bump
    )]
    pub born2bewild: Account<'info, Config>,

    // Initialize the WILD token mint with the platform PDA as authority
    #[account(
        init,
        payer = admin,
        mint::decimals = 9,
        mint::authority = born2bewild,
        mint::freeze_authority = born2bewild
    )]
    pub wild_token_mint: Account<'info, Mint>,

    pub system_program: Program<'info, System>,
    pub token_program: Program<'info, Token>,
    pub rent: Sysvar<'info, Rent>,
}

impl<'info> Initialize<'info> {
    pub fn init(&mut self, name: String, bumps: &InitializeBumps) -> Result<()> {
        require!(name.len() > 0 && name.len() < 33, ConfigError::NameTooLong);
        
        self.born2bewild.set_inner(Config {
            admin: self.admin.key(),
            name,
            bump: bumps.born2bewild,
            wild_token_mint: self.wild_token_mint.key(),  // Store the mint address
        });

        Ok(())
    }

    /*pub fn init_wild_token(&mut self, bumps: &InitializeBumps) -> Result<()> {
        let platform_seeds = &[
            b"born2bewild",
            self.platform.name.as_str().as_bytes(),
            &[self.platform.bump]
        ];
        let signer = &[&platform_seeds[..]];
    }*/
}
