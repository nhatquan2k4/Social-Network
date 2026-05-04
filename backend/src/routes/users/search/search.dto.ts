import {
    DEFAULT_SEARCH_LIMIT,
    DEFAULT_SEARCH_PAGE,
    MAX_SEARCH_LIMIT,
} from '../shared/users.constants.js';

export function parseSearchName(raw: unknown): string {
    if (typeof raw !== 'string' || raw.trim().length === 0) {
        throw new Error('name la bat buoc va khong duoc de trong');
    }
    return raw.trim();
}

export function parseSearchPage(raw: unknown): number {
    const page = Number(raw);
    if (!Number.isInteger(page) || page < 1) {
        return DEFAULT_SEARCH_PAGE;
    }
    return page;
}

export function parseSearchLimit(raw: unknown): number {
    const limit = Number(raw);
    if (!Number.isInteger(limit) || limit < 1) {
        return DEFAULT_SEARCH_LIMIT;
    }
    return Math.min(limit, MAX_SEARCH_LIMIT);
}
