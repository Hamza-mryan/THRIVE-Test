import { Routes } from '@angular/router';
export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
  {
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.page').then((m) => m.DashboardPage),
  },
  {
    path: 'services',
    loadComponent: () => import('./features/services/services.page').then((m) => m.ServicesPage),
  },
  {
    path: 'resources',
    loadComponent: () => import('./features/resources/resources.page').then((m) => m.ResourcesPage),
  },
  {
    path: 'referrals',
    loadComponent: () => import('./features/referrals/referrals.page').then((m) => m.ReferralsPage),
  },
  { path: '**', redirectTo: 'dashboard' },
];
