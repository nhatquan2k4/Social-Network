// Refresh token is read from httpOnly cookie, no body fields required
export interface RefreshTokenDto {
    refreshToken: string;
}
