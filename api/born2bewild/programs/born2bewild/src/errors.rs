use anchor_lang::error_code;

#[error_code]
pub enum DonationError {
    #[msg("Insufficient funds to donate")]
    InsufficientFunds,
}

pub enum DonationProjectError {
    #[msg("Only the project creator can withdraw funds")]
    UnauthorizedWithdrawal,
    #[msg("Insufficient funds to withdraw")]
    InsufficientFunds,
}

pub enum ConfigError {
    #[msg("Name too long")]
    NameTooLong,
}
