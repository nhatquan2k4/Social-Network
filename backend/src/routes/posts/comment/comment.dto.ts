export interface CreateCommentDto {
    content: string;
    parentCommentId?: string;
}

export interface UpdateCommentDto {
    content: string;
}
