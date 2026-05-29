import { z } from 'zod'

export const userSchema = z.object({
  id: z.number(),
  username: z.string(),
  email: z.email(),
})

export type User = z.infer<typeof userSchema>
