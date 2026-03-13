export interface AuthUser {
    userId: string
    email: string
    name: string
    password: string
    role: string
    createdAt: Date
    createdBy: string | null
    updatedAt: Date
    updatedBy: string | null
}

export interface CreateUserInput{
    email: string
    name: string
    password: string
}

export interface SearchUserInput{
    email: string
    password: string
}

export interface SafeUserDataDTO{
    id: string
    email: string
    name: string
    role: string
}