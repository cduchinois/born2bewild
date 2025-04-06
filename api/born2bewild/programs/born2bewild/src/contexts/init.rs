//init born2bewild plateform
use anchor_lang::prelude::*;
use anchor_spl::token_interface::TokenInterface;

use crate::state::Config;
use crate::errors::ConfigError;

#[derive(Accounts)]
#[instruction(name: String, wild_token_mint: Pubkey)]
pub struct Initialize<'info> {
    #[account(mut)]
    admin: Signer<'info>,
    #[account(
        init,
        space = Config::INIT_SPACE,
        payer = admin,
        seeds = [b"born2bewild", name.as_str().as_bytes()],
        bump
    )]
    born2bewild: Account<'info, Config>, //changed this from Box
    system_program: Program<'info, System>,
}

impl<'info> Initialize<'info> {
    pub fn init(&mut self, name: String, bumps: &InitializeBumps) -> Result<()> {
    
        require!(name.len() > 0 && name.len() < 33, ConfigError::NameTooLong);
        self.born2bewild.set_inner(Config {
            admin: self.admin.key(),
            name,
            wild_token_mint,
            bump: bumps.born2bewild,
        });

        Ok(())
    }
}
