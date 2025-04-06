//Donation project config

use anchor_lang::prelude::*;

#[account]
pub struct DonationProject {
    pub creator: Pubkey,
    pub name: String, 
    pub description: String,
    pub location: String,
    pub target_amount: u64,
    pub target_animal: String,
    pub total_donation: u64,
    pub project_bump: u8,
    pub treasury_bump: u8,
}

impl Space for DonationProject {
    const INIT_SPACE: usize = 8 + 32 + (4 + 32) + (4 + 32) + (4 + 32) + 8 + (4 + 32) + 8 + 1 + 1; // Updated space calculation
}