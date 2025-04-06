use anchor_lang::prelude::*;
use anchor_spl::{
    token_interface::{TokenAccount, Mint, TokenInterface}, 
    metadata::{Metadata, MetadataAccount, MasterEditionAccount}, 
    associated_token::AssociatedToken
};

use crate::state::{DonationProject, ConfigError};

#[derive(Accounts)]
#[instruction(name: String, description: String, wild_token_mint: Pubkey, location: String, target_amount: u64, target_animal: String)]
pub struct CreateProject<'info> {
    #[account(
        init,
        payer = creator,
        space = DonationProject::INIT_SPACE, 
        seeds = [b"project", name.as_str().as_bytes()],
        bump
    )]
    pub project: Account<'info, DonationProject>,
    
    #[account(mut)]
    pub creator: Signer<'info>,  // Any signer can create a project
    
    #[account(
        seeds = [b"treasury", project.key().as_ref()],
        bump
    )]
    pub treasury: SystemAccount<'info>,
    
    pub system_program: Program<'info, System>,
}

impl<'info> CreateProject<'info> {
    pub fn create_project(&mut self, name: String, description: String, wild_token_mint: Pubkey, location: String, target_amount: u64, target_animal: String) -> Result<()> {
        require!(name.len() > 0 && name.len() < 33, ConfigError::NameTooLong);
        self.project.set_inner(DonationProject {
            creator: self.creator.key(),
            name,
            description,
            location,
            target_amount,
            target_animal, // TODO: add animal metadata / id 
            wild_token_mint,
            total_donation: 0,
            treasury_bump: self.treasury.key().bump,
        });

        Ok(())
    }
}
