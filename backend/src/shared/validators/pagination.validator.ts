export interface PaginationInput {
  page?: number;
  limit?: number;
  maxLimit?: number;
}

export interface PaginationResult {
  page: number;
  limit: number;
}

export const normalizePagination = ({
  page = 1,
  limit = 20,
  maxLimit = 50,
}: PaginationInput): PaginationResult => {
  const safePage = Math.max(1, Number(page) || 1);
  const safeLimit = Math.max(1, Math.min(Number(limit) || 20, maxLimit));

  return {
    page: safePage,
    limit: safeLimit,
  };
};
