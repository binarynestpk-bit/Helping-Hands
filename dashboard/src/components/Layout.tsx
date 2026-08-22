import { ReactNode, useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/router';
import {
  LayoutDashboard,
  Users,
  Droplet,
  GraduationCap,
  Heart,
  Handshake,
  Inbox,
  UserX,
  Bell,
  Settings,
  LogOut,
  Menu,
  X,
  ChevronDown,
} from 'lucide-react';
import { notificationsAPI } from '@/services/api';

interface LayoutProps {
  children: ReactNode;
}

const NOTIF_LAST_SEEN_KEY = 'notif_last_seen';

const notifTypeColor: Record<string, string> = {
  blood: 'bg-red-500',
  education: 'bg-green-500',
  family: 'bg-yellow-500',
  user: 'bg-blue-500',
};

function timeAgo(dateStr: string): string {
  const then = new Date(dateStr).getTime();
  if (isNaN(then)) return '';
  const seconds = Math.floor((Date.now() - then) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  return `${weeks}w ago`;
}

const allMenuItems = [
  { icon: LayoutDashboard, label: 'Dashboard',          path: '/dashboard',                   roles: ['super_admin', 'blood_admin', 'education_admin', 'family_admin'] },
  { icon: Users,           label: 'User Management',    path: '/dashboard/users',              roles: ['super_admin'] },
  { icon: Droplet,         label: 'Blood Requests',     path: '/dashboard/blood-requests',     roles: ['super_admin', 'blood_admin'] },
  { icon: GraduationCap,   label: 'Education Requests', path: '/dashboard/education-requests', roles: ['super_admin', 'education_admin'] },
  { icon: Heart,           label: 'Family Support',     path: '/dashboard/family-requests',    roles: ['super_admin', 'family_admin'] },
  { icon: Handshake,       label: 'Partners',           path: '/dashboard/partners',           roles: ['super_admin'] },
  { icon: Inbox,           label: 'Partner Requests',   path: '/dashboard/partner-requests',   roles: ['super_admin'] },
  { icon: UserX,           label: 'Account Deletions',  path: '/dashboard/deletion-requests',  roles: ['super_admin'] },
];

export default function Layout({ children }: LayoutProps) {
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const notifRef = useRef<HTMLDivElement>(null);

  const role = typeof window !== 'undefined' ? localStorage.getItem('admin_role') || 'super_admin' : 'super_admin';
  const menuItems = allMenuItems.filter(item => item.roles.includes(role));

  const roleLabel: Record<string, string> = {
    super_admin: 'Super Admin',
    blood_admin: 'Blood Admin',
    education_admin: 'Education Admin',
    family_admin: 'Family Admin',
  };

  const computeUnread = (items: any[]) => {
    const lastSeen = localStorage.getItem(NOTIF_LAST_SEEN_KEY);
    if (!lastSeen) {
      // First ever load: treat current fetch as the baseline so nothing shows
      // as unread. Store the newest item's time (or now) as last seen.
      const baseline = items[0]?.created_at || new Date().toISOString();
      localStorage.setItem(NOTIF_LAST_SEEN_KEY, baseline);
      return 0;
    }
    const lastSeenTime = new Date(lastSeen).getTime();
    return items.filter((n) => new Date(n.created_at).getTime() > lastSeenTime).length;
  };

  const fetchNotifications = async () => {
    try {
      const response = await notificationsAPI.getAll();
      const items: any[] = response.data.data || [];
      setNotifications(items);
      setUnreadCount(computeUnread(items));
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
    }
  };

  useEffect(() => {
    fetchNotifications();
    const interval = setInterval(fetchNotifications, 30000);
    return () => clearInterval(interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Close dropdowns when clicking outside the bell area.
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setNotifOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleBellClick = () => {
    const next = !notifOpen;
    setNotifOpen(next);
    if (next) {
      // Opening marks everything seen.
      localStorage.setItem(NOTIF_LAST_SEEN_KEY, new Date().toISOString());
      setUnreadCount(0);
    }
  };

  const handleNotifClick = (link: string) => {
    setNotifOpen(false);
    if (link) router.push(link);
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_role');
    localStorage.removeItem('admin_user');
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
                <h1 className="text-lg font-bold text-neutral-900">Trusting Hand</h1>
                <p className="text-xs font-medium text-primary-600">{roleLabel[role] || 'Admin'}</p>
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
              <div className="relative" ref={notifRef}>
                <button
                  onClick={handleBellClick}
                  className="relative p-2 text-neutral-400 hover:text-neutral-600 hover:bg-neutral-100 rounded-lg transition-colors"
                >
                  <Bell className="h-5 w-5" />
                  {unreadCount > 0 && (
                    <span className="absolute -top-0.5 -right-0.5 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-red-500 px-1 text-[10px] font-bold text-white ring-2 ring-white">
                      {unreadCount > 9 ? '9+' : unreadCount}
                    </span>
                  )}
                </button>

                {notifOpen && (
                  <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-strong border border-neutral-200 z-20">
                    <div className="px-4 py-3 border-b border-neutral-200">
                      <h3 className="text-sm font-semibold text-neutral-900">Notifications</h3>
                    </div>
                    <div className="max-h-96 overflow-y-auto">
                      {notifications.length === 0 ? (
                        <div className="px-4 py-8 text-center text-sm text-neutral-500">
                          No notifications
                        </div>
                      ) : (
                        notifications.map((notif) => (
                          <button
                            key={notif.id}
                            onClick={() => handleNotifClick(notif.link)}
                            className="w-full text-left flex items-start gap-3 px-4 py-3 hover:bg-neutral-50 transition-colors border-b border-neutral-100 last:border-b-0"
                          >
                            <span
                              className={`mt-1.5 flex-shrink-0 h-2.5 w-2.5 rounded-full ${
                                notifTypeColor[notif.type] || 'bg-neutral-400'
                              }`}
                            ></span>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm text-neutral-900 truncate">{notif.title}</p>
                              <div className="flex items-center gap-2 mt-1">
                                <span className="text-xs text-neutral-400">
                                  {timeAgo(notif.created_at)}
                                </span>
                                {notif.status && (
                                  <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-neutral-100 text-neutral-600">
                                    {notif.status}
                                  </span>
                                )}
                              </div>
                            </div>
                          </button>
                        ))
                      )}
                    </div>
                  </div>
                )}
              </div>

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
                    <button
                      onClick={() => {
                        setUserMenuOpen(false);
                        router.push('/dashboard/profile');
                      }}
                      className="w-full text-left block px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50"
                    >
                      Profile
                    </button>
                    <button
                      onClick={() => {
                        setUserMenuOpen(false);
                        router.push('/dashboard/profile');
                      }}
                      className="w-full text-left block px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50"
                    >
                      Settings
                    </button>
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
