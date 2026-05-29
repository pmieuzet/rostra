import { z } from 'zod'

export const registerUserSchema = z.object({
  username: z.string().min(3, 'Username is required'),
  email: z.email('Invalid email'),
})

export type RegisterUserForm = z.infer<typeof registerUserSchema>
