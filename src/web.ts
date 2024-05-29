import { WebPlugin } from '@capacitor/core';

import type { NotifyPersistentPlugin } from './definitions';

export class NotifyPersistentWeb
  extends WebPlugin
  implements NotifyPersistentPlugin
{
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
