use anchor_lang::prelude::*;

#[account]
pub struct Donation {
    pub donor: Pubkey,
    pub amount: u64,
    pub bump: u8,
}

impl Space for Donation {
    const INIT_SPACE: usize = 8 + 32 + 8 + 1;
}