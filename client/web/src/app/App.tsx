import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { UsersPage } from '../pages/users/ui/UsersPage'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <UsersPage />
    </QueryClientProvider>
  )
}

export default App
