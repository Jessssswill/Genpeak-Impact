export interface RegisterUser {
    email: string
    name: string
    password: string
    role: string
    createdAt: Date
    createdBy: string | null
    updatedAt: Date
    updatedBy: string | null
}