import { AuthUser } from "./auth.types";

export interface JwtPayload {
    id: string
    role: string
}

declare global{
    namespace Express{
        interface Request{
            user?: AuthUser;
            jwtPayload?: JwtPayload;
        }
    }
}