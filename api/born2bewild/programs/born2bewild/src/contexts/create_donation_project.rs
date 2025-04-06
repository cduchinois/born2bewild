use anchor_lang::prelude::*;

use crate::errors::*;
use crate::state::{Config, DonationProject};

#[derive(Accounts)]
#[instruction(name: String, description: String, location: String, target_amount: u64, target_animal: String)]
pub struct CreateProject<'info> {
    // Platform config that holds the universal WILD mint
    #[account(
        seeds = [b"born2bewild", platform.name.as_str().as_bytes()],
        bump
    )]
    pub platform: Account<'info, Config>,

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
    pub fn create_project(&mut self, name: String, description: String, location: String, target_amount: u64, target_animal: String, bumps: &CreateProjectBumps) -> Result<()> {
        require!(name.len() > 0 && name.len() < 33, ConfigError::NameTooLong);
        self.project.set_inner(DonationProject {
            creator: self.creator.key(),
            name,
            description,
            location,
            target_amount,
            target_animal, // TODO: add animal metadata / id 
            total_donation: 0,
            project_bump: bumps.project,
            treasury_bump: bumps.treasury,
        });

        Ok(())
    }
}
