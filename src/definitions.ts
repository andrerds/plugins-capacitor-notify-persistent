export interface NotifyPersistentPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
