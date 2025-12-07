import { ReactNode, useState } from 'react';
import { useRouter } from 'next/router';
import {
  LayoutDashboard,
  Users,
  Droplet,
  GraduationCap,
  Heart,
  Bell,
  Settings,
  LogOut,
  Menu,
  X,
  ChevronDown,
} from 'lucide-react';

interface LayoutProps {
  children: ReactNode;
}

const menuItems = [
  {
    icon: LayoutDashboard,
    label: 'Dashboard',
    path: '/dashboard',
  },
  {
    icon: Users,
    label: 'User Management',
    path: '/dashboard/users',
  },
  {
    icon: Droplet,
    label: 'Blood Requests',
    path: '/dashboard/blood-requests',
  },
  {
    icon: GraduationCap,
    label: 'Education Requests',
    path: '/dashboard/education-requests',
  },
  {
    icon: Heart,
    label: 'Family Support',
    path: '/dashboard/family-requests',
  },
  {
    icon: Bell,
    label: 'Notifications',
    path: '/dashboard/notifications',
  },
  {
    icon: Settings,
    label: 'Settings',
    path: '/dashboard/settings',
  },
];

export default function Layout({ children }: LayoutProps) {
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    router.push('/login');
  };

  return (
    <div className="min-h-screen bg-neutral-50">
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-72 lg:flex-col">
        <div className="flex flex-col flex-grow bg-white border-r border-neutral-200 pt-5 pb-4 overflow-y-auto">
          <div className="flex items-center flex-shrink-0 px-6 mb-8">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-primary-500 flex items-center justify-center">
                <Heart className="w-6 h-6 text-white" fill="currentColor" />
              </div>
              <div>
                <h1 className="text-lg font-bold text-neutral-900">Helping Hand</h1>
                <p className="text-xs text-neutral-500">Admin Portal</p>
              </div>
            </div>
          </div>

          <nav className="flex-1 px-3 space-y-1">
            {menuItems.map((item) => {
              const Icon = item.icon;
              const isActive = router.pathname === item.path;
              return (
                <button
                  key={item.path}
                  onClick={() => router.push(item.path)}
                  className={`w-full group flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-all duration-200 ${
                    isActive
                      ? 'bg-primary-50 text-primary-700'
                      : 'text-neutral-600 hover:bg-neutral-50 hover:text-neutral-900'
                  }`}
                >
                  <Icon
                    className={`mr-3 flex-shrink-0 h-5 w-5 ${
                      isActive ? 'text-primary-600' : 'text-neutral-400 group-hover:text-neutral-600'
                    }`}
                  />
                  {item.label}
                </button>
              );
            })}
          </nav>

          <div className="flex-shrink-0 px-3 mt-4 pt-4 border-t border-neutral-200">
            <button
              onClick={handleLogout}
              className="w-full group flex items-center px-3 py-2.5 text-sm font-medium rounded-lg text-red-600 hover:bg-red-50 transition-all duration-200"
            >
              <LogOut className="mr-3 flex-shrink-0 h-5 w-5" />
              Logout
            </button>
          </div>
        </div>
      </div>

      <div className="lg:pl-72 flex flex-col flex-1">
        <div className="sticky top-0 z-10 flex-shrink-0 flex h-16 bg-white border-b border-neutral-200 shadow-sm">
          <button
            type="button"
            className="px-4 text-neutral-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500 lg:hidden"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="h-6 w-6" />
          </button>

          <div className="flex-1 px-4 flex justify-between items-center">
            <div className="flex-1 flex">
              <div className="w-full max-w-lg">
                <label htmlFor="search" className="sr-only">
                  Search
                </label>
                <div className="relative">
                  <input
                    id="search"
                    className="input-field pl-4 pr-4 text-sm"
                    placeholder="Search users, requests..."
                    type="search"
                  />
                </div>
              </div>
            </div>

            <div className="ml-4 flex items-center gap-4">
              <button className="relative p-2 text-neutral-400 hover:text-neutral-600 hover:bg-neutral-100 rounded-lg transition-colors">
                <Bell className="h-5 w-5" />
                <span className="absolute top-1 right-1 block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white"></span>
              </button>

              <div className="relative">
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className="flex items-center gap-3 p-2 hover:bg-neutral-100 rounded-lg transition-colors"
                >
                  <div className="w-8 h-8 rounded-full bg-primary-500 flex items-center justify-center text-white font-semibold text-sm">
                    AD
                  </div>
                  <div className="hidden md:block text-left">
                    <p className="text-sm font-medium text-neutral-900">Admin User</p>
                    <p className="text-xs text-neutral-500">Super Admin</p>
                  </div>
                  <ChevronDown className="h-4 w-4 text-neutral-400" />
                </button>

                {userMenuOpen && (
                  <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-strong border border-neutral-200 py-1">
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50"
                    >
                      Profile
                    </a>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50"
                    >
                      Settings
                    </a>
                    <hr className="my-1 border-neutral-200" />
                    <button
                      onClick={handleLogout}
                      className="w-full text-left block px-4 py-2 text-sm text-red-600 hover:bg-red-50"
                    >
                      Logout
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        <main className="flex-1">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">{children}</div>
          </div>
        </main>
      </div>

      {sidebarOpen && (
        <div className="fixed inset-0 z-40 flex lg:hidden">
          <div
            className="fixed inset-0 bg-neutral-600 bg-opacity-75"
            onClick={() => setSidebarOpen(false)}
          ></div>

          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setSidebarOpen(false)}
              >
                <X className="h-6 w-6 text-white" />
              </button>
            </div>

            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4 mb-6">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-primary-500 flex items-center justify-center">
                    <Heart className="w-6 h-6 text-white" fill="currentColor" />
                  </div>
                  <div>
                    <h1 className="text-lg font-bold text-neutral-900">Helping Hand</h1>
                    <p className="text-xs text-neutral-500">Admin Portal</p>
                  </div>
                </div>
              </div>

              <nav className="px-2 space-y-1">
                {menuItems.map((item) => {
                  const Icon = item.icon;
                  const isActive = router.pathname === item.path;
                  return (
                    <button
                      key={item.path}
                      onClick={() => {
                        router.push(item.path);
                        setSidebarOpen(false);
                      }}
                      className={`w-full group flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-all duration-200 ${
                        isActive
                          ? 'bg-primary-50 text-primary-700'
                          : 'text-neutral-600 hover:bg-neutral-50 hover:text-neutral-900'
                      }`}
                    >
                      <Icon
                        className={`mr-3 flex-shrink-0 h-5 w-5 ${
                          isActive
                            ? 'text-primary-600'
                            : 'text-neutral-400 group-hover:text-neutral-600'
                        }`}
                      />
                      {item.label}
                    </button>
                  );
                })}
              </nav>
            </div>

            <div className="flex-shrink-0 px-2 pb-4 border-t border-neutral-200 pt-4">
              <button
                onClick={handleLogout}
                className="w-full group flex items-center px-3 py-2.5 text-sm font-medium rounded-lg text-red-600 hover:bg-red-50 transition-all duration-200"
              >
                <LogOut className="mr-3 flex-shrink-0 h-5 w-5" />
                Logout
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
