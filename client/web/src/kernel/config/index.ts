const apiBaseUrl = import.meta.env.VITE_API_BASE_URL

if (!apiBaseUrl) {
  throw new Error(
    '[kernel/config] VITE_API_BASE_URL is not defined. ' +
      'Create a .env file at client/web/.env with VITE_API_BASE_URL=http://localhost:8080',
  )
}

export const API_BASE_URL: string = apiBaseUrl
