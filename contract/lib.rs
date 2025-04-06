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

    // 🆕 Add donate logic
    pub fn donate(ctx: Context<Donate>, amount: u64) -> Result<()> {
        let donor = &ctx.accounts.donor;
        let project = &mut ctx.accounts.project;

        require!(amount > 0, DonationError::InvalidDonationAmount);

        // Transfer SOL from donor to project PDA
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &donor.key(),
            &project.key(),
            amount,
        );

        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                donor.to_account_info(),
                project.to_account_info(),
                ctx.accounts.system_program.to_account_info(),
            ],
        )?;

        // Update project’s current amount
        project.current_amount = project.current_amount.checked_add(amount).unwrap();

        emit!(DonationMade {
            donor: donor.key(),
            project: project.key(),
            amount,
            new_total: project.current_amount,
        });

        Ok(())
    }

    pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
        let admin = &ctx.accounts.admin;
        let project = &mut ctx.accounts.project;

        // Only the project admin can withdraw
        require_keys_eq!(project.admin, admin.key(), DonationError::Unauthorized);

        // Check sufficient balance
        require!(
            amount <= project.current_amount,
            DonationError::InsufficientFunds
        );

        // Transfer SOL from project PDA to admin
        **project.to_account_info().try_borrow_mut_lamports()? -= amount;
        **admin.to_account_info().try_borrow_mut_lamports()? += amount;

        // Update project balance
        project.current_amount = project.current_amount.checked_sub(amount).unwrap();

        emit!(WithdrawalMade {
            admin: admin.key(),
            project: project.key(),
            amount,
            remaining_balance: project.current_amount,
        });

        Ok(())
    }

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

#[derive(Accounts)]
pub struct Donate<'info> {
    #[account(mut)]
    pub donor: Signer<'info>,

    #[account(mut, seeds = [b"project", project.admin.as_ref(), project.name.as_bytes()], bump = project.bump)]
    pub project: Account<'info, Project>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut)]
    pub admin: Signer<'info>,

    #[account(mut, seeds = [b"project", project.admin.as_ref(), project.name.as_bytes()], bump = project.bump)]
    pub project: Account<'info, Project>,
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

// Event emitted when a new project is created
#[event]
pub struct ProjectCreated {
    pub project_id: Pubkey,
    pub admin: Pubkey,
    pub name: String,
    pub target_amount: u64,
    pub target_animal: String,
}
#[event]
pub struct DonationMade {
    pub donor: Pubkey,
    pub project: Pubkey,
    pub amount: u64,
    pub new_total: u64,
}
#[event]
pub struct WithdrawalMade {
    pub admin: Pubkey,
    pub project: Pubkey,
    pub amount: u64,
    pub remaining_balance: u64,
}

#[error_code]
pub enum DonationError {
    #[msg("The donation amount must be greater than zero.")]
    InvalidDonationAmount,
    #[msg("You are not authorized to perform this action.")]
    Unauthorized,
    #[msg("Insufficient funds in project treasury.")]
    InsufficientFunds,
}

