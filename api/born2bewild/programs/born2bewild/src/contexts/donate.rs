use anchor_lang::prelude::*;
use anchor_spl::{
    token_interface::{TokenAccount, Mint, TokenInterface, MintTo}, 
    metadata::{Metadata, MetadataAccount, MasterEditionAccount}, 
    associated_token::AssociatedToken
};

use crate::state::{DonationError, Config};

#[derive(Accounts)]
#[instruction(project_name: String, amount: u64)]
pub struct Donate<'info> {
    #[account(mut)]
    pub donor: Signer<'info>,
    
    // Platform config that holds the universal WILD mint
    #[account(
        seeds = [b"born2bewild", platform.name.as_str().as_bytes()],
        bump = platform.bump
    )]
    pub platform: Account<'info, Config>,
    
    #[account(mut)]
    pub wild_token_mint: Account<'info, Mint>, 
    
    #[account(mut)]
    pub wild_token_account: Account<'info, TokenAccount>,
    
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
    
    pub token_program: Program<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}

impl<'info> Donate<'info> {
    pub fn donate(&mut self, amount: u64) -> Result<()> {
        // Transfer SOL from donor to treasury
        system_program::transfer(
            CpiContext::new(
                self.system_program.to_account_info(),
                Transfer {
                    from: self.donor.to_account_info(),
                    to: self.treasury.to_account_info(),
                },
            ),
            amount,
        )?;

        // Mint $WILD tokens to donor's token account
        // For simplicity, let's say 1 SOL = 100 $WILD
        let wild_amount = amount * 100;
        
        // Create CPI context with platform PDA signer seeds
        let platform_seeds = &[
            b"born2bewild",
            self.platform.name.as_str().as_bytes(),
            &[self.platform.bump]
        ];
        let signer = &[&platform_seeds[..]];
        
        token::mint_to(
            CpiContext::new_with_signer(
                self.token_program.to_account_info(),
                MintTo {
                    mint: self.wild_token_mint.to_account_info(),
                    to: self.wild_token_account.to_account_info(),
                    authority: self.platform.to_account_info(),
                },
                signer
            ),
            wild_amount,
        )?;

        self.project.total_donations += amount;
        
        Ok(())
    }
}
