//Plateform config

use anchor_lang::prelude::*;

#[account]
pub struct Config {
    pub admin: Pubkey,
    pub name: String,
    pub bump: u8,
    pub wild_token_mint: Pubkey,
}

impl Space for Config {
    const INIT_SPACE: usize = 8 + 32 + (4 + 32) + 1 + 32;
}