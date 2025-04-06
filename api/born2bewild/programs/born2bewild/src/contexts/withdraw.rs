use anchor_lang::prelude::*;
use anchor_lang::solana_program::system_instruction;

use crate::errors::*;
use crate::state::{Config, DonationProject};

#[derive(Accounts)]
#[instruction(project_name: String, amount: u64)]
pub struct Withdraw<'info> {
    // Platform config that holds the universal WILD mint
    #[account(
        seeds = [b"born2bewild", platform.name.as_str().as_bytes()],
        bump
    )]
    pub platform: Account<'info, Config>,

    #[account(
        seeds = [b"project", project_name.as_str().as_bytes()],
        bump
    )]
    pub project: Account<'info, DonationProject>,
    
    #[account(
        seeds = [b"treasury", project.key().as_ref()],
        bump
    )]
    pub treasury: SystemAccount<'info>,
    
    #[account(mut)]
    pub recipient: Signer<'info>, //project creator

    pub system_program: Program<'info, System>,
}

impl<'info> Withdraw<'info> {
    pub fn withdraw(&mut self, amount: u64) -> Result<()> {
        // Define the seeds and bump for the PDA
        let binding = self.project.key();
        let treasury_seeds = &[b"treasury", binding.as_ref(), &[self.project.treasury_bump]];
        let signer_seeds = &[&treasury_seeds[..]];

        //check if the recipient is the creator of the project
        if self.recipient.key() != self.project.creator {
            return Err(DonationProjectError::UnauthorizedWithdrawal.into());
        }

        //check if the amount is greater than the total donations
        if amount > self.project.total_donation {
            return Err(DonationProjectError::InsufficientFunds.into());
        }

        // Create the transfer instruction
        let ix = system_instruction::transfer(
            self.treasury.to_account_info().key,
            self.recipient.to_account_info().key,
            amount,
        );

        // Invoke the transfer instruction with the PDA signing
        anchor_lang::solana_program::program::invoke_signed(
            &ix,
            &[
                self.treasury.to_account_info(),
                self.recipient.to_account_info(),
                self.system_program.to_account_info(),
            ],
            signer_seeds,
        )?;

        //update the project total donations
        self.project.total_donation -= amount;
        Ok(())
    }
}
