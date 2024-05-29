import { registerPlugin } from '@capacitor/core';

import type { NotifyPersistentPlugin } from './definitions';

const NotifyPersistent = registerPlugin<NotifyPersistentPlugin>(
  'NotifyPersistent',
  {
    web: () => import('./web').then(m => new m.NotifyPersistentWeb()),
  },
);

export * from './definitions';
export { NotifyPersistent };
