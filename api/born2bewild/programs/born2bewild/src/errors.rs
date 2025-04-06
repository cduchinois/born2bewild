use anchor_lang::error_code;

#[error_code]
pub enum DonationError {
    #[msg("Invalid donation amount")]
    InvalidDonationAmount,
}

#[error_code]
pub enum DonationProjectError {
    #[msg("Only the project creator can withdraw funds")]
    UnauthorizedWithdrawal,
    #[msg("Insufficient funds to withdraw")]
    InsufficientFunds,
}

#[error_code]
pub enum ConfigError {
    #[msg("Name too long")]
    NameTooLong,
}
