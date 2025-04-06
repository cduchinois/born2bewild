use anchor_lang::{prelude::*, system_program::{Transfer, transfer}};
use anchor_spl::token_interface::{
    Mint,
    TokenInterface,
    TokenAccount,
    mint_to,
    MintTo
};

use crate::errors::*;
use crate::state::{Config, DonationProject};

#[derive(Accounts)]
#[instruction(project_name: String, amount: u64)]
pub struct Donate<'info> {
    #[account(mut)]
    pub donor: Signer<'info>,
    
    // Platform config that holds the universal WILD mint
    #[account(
        seeds = [b"born2bewild", platform.name.as_str().as_bytes()],
        bump
    )]
    pub platform: Account<'info, Config>,
    
    #[account(mut)]
    pub wild_token_mint: InterfaceAccount<'info, Mint>,

    #[account(mut)]
    pub wild_token_account: InterfaceAccount<'info, TokenAccount>,
    
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
    
    pub token_program: Interface<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}

impl<'info> Donate<'info> {
    fn transfer_sol(&self, amount: u64) -> Result<()> {
        let accounts = Transfer {
            from: self.donor.to_account_info(),
            to: self.treasury.to_account_info(),
        };
        let cpi_context = CpiContext::new(self.system_program.to_account_info(), accounts);
        transfer(cpi_context, amount)
    }

    fn mint_wild(&self, amount: u64) -> Result<()> {
        let platform_seeds = &[
            b"born2bewild",
            self.platform.name.as_str().as_bytes(),
            &[self.platform.bump]
        ];
        let signer = &[&platform_seeds[..]];
        
        let cpi_context = CpiContext::new_with_signer(
            self.token_program.to_account_info(),
            MintTo {
                mint: self.wild_token_mint.to_account_info(),
                to: self.wild_token_account.to_account_info(),
                authority: self.platform.to_account_info(),
            },
            signer
        );

        mint_to(cpi_context, amount)
    }

    pub fn donate(&mut self, amount: u64) -> Result<()> {
        require!(amount > 0, DonationError::InvalidDonationAmount);
        
        // Transfer SOL from donor to treasury
        self.transfer_sol(amount)?;

        // Mint $WILD tokens to donor's token account
        // For simplicity, let's say 1 SOL = 100 $WILD
        let wild_amount = amount * 100;
        
        self.mint_wild(wild_amount)?;

        self.project.total_donation += amount;
        
        Ok(())
    }
}
