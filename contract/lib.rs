use anchor_lang::prelude::*;

declare_id!("F5AmVjKkazHx9tq8MziWcVjQP4mrqavDc2GSpbwKy5Zj");

#[program]
pub mod donation_system {
    use super::*;

    pub fn create_project(
        ctx: Context<CreateProject>,
        name: String,
        location: String,
        target_amount: u64,
        target_animal: String,
    ) -> Result<()> {
        let project = &mut ctx.accounts.project;

        // Set the project fields
        project.admin = ctx.accounts.admin.key();
        project.name = name;
        project.location = location;
        project.target_amount = target_amount;
        project.current_amount = 0;
        project.target_animal = target_animal;
        //project.bump = *ctx.bumps.project;
        project.bump = ctx.bumps.project; // Fixed: Direct access without dereferencing

        // Emit an event for the new project
        emit!(ProjectCreated {
            project_id: project.key(),
            admin: project.admin,
            name: project.name.clone(),
            target_amount,
            target_animal: project.target_animal.clone(),
        });

        Ok(())
    }
}

// Event emitted when a new project is created
#[event]
pub struct ProjectCreated {
    pub project_id: Pubkey,
    pub admin: Pubkey,
    pub name: String,
    pub target_amount: u64,
    pub target_animal: String,
}

#[derive(Accounts)]
#[instruction(
    name: String,
    location: String,
    target_amount: u64,
    target_animal: String,
)]
pub struct CreateProject<'info> {
    #[account(
        init,
        payer = admin,
        space = 8 + // discriminator
               32 + // admin: Pubkey
               4 + name.len() + // name: String
               4 + location.len() + // location: String
               8 + // target_amount: u64
               8 + // current_amount: u64
               4 + target_animal.len() + // target_animal: String
               1 + // bump: u8
               32, // extra space for future updates
        seeds = [b"project", admin.key().as_ref(), name.as_bytes()],
        bump
    )]
    pub project: Account<'info, Project>,

    #[account(mut)]
    pub admin: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[account]
pub struct Project {
    pub admin: Pubkey,         // The creator/admin of the project
    pub name: String,          // Project name
    pub location: String,      // Project location
    pub target_amount: u64,    // Fundraising goal in lamports
    pub current_amount: u64,   // Current amount raised in lamports
    pub target_animal: String, // Animal targeted by this project
    pub bump: u8,              // PDA bump seed
}

