import { API_BASE_URL } from '../config'

export interface ErrorType<T> {
  status: number
  data: T
}

/**
 * Custom fetcher injected into orval-generated hooks.
 * Prepends API_BASE_URL to every request and forwards the JWT if present.
 */
export async function apiFetcher<T>(url: string, options?: RequestInit): Promise<T> {
  const token = sessionStorage.getItem('access_token')

  const response = await fetch(`${API_BASE_URL}${url}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options?.headers,
    },
  })

  if (!response.ok) {
    const data: unknown = await response.json().catch(() => ({}))
    throw { status: response.status, data } satisfies ErrorType<unknown>
  }

  return response.json() as Promise<T>
}
