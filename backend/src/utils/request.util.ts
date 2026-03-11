export function handleError(error: unknown): Error {
    if (error instanceof Error) {
        return error;
    }
    return new Error('unkown error occurred');
}