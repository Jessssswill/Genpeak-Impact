export interface ServiceResponse<T = any> {
    data?: T | null;
    message: string;
    statusCode: number;
}
