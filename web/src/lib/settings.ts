export interface StoredValue<T> {
    value: T;
}

export function normalizePollIntervalMs(value: unknown): number {
    const numeric = Number(value);
    return Number.isFinite(numeric) ? Math.max(1, Math.round(numeric)) : 100;
}

export function createStoredRef<T>(key: string, fallbackValue: T, normalize: (value: unknown) => T = (value) => value as T): StoredValue<T> {
    let initial = fallbackValue;
    try {
        const stored = window.localStorage.getItem(key);
        if (stored != null) initial = normalize(JSON.parse(stored));
    } catch {
        initial = normalize(fallbackValue);
    }
    let current = normalize(initial);
    return {
        get value() { return current; },
        set value(next: T) { current = normalize(next); window.localStorage.setItem(key, JSON.stringify(current)); },
    };
}
