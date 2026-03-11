import { RegisterUser } from "./userRegister.types";

declare global{
    namespace Express{
        interface Request{
            user?: RegisterUser;
        }
    }
}