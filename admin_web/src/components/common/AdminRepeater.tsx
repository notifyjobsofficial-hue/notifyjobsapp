import React from 'react';
import { Plus, Trash2, ArrowUp, ArrowDown } from 'lucide-react';
import { AdminButton } from './AdminButton';

interface AdminRepeaterProps<T> {
  title: string;
  description?: string;
  items: T[];
  onAdd: () => void;
  onRemove: (index: number) => void;
  onMoveUp?: (index: number) => void;
  onMoveDown?: (index: number) => void;
  renderItem: (item: T, index: number) => React.ReactNode;
  addButtonLabel?: string;
  maxItems?: number;
}

export function AdminRepeater<T>({
  title,
  description,
  items,
  onAdd,
  onRemove,
  onMoveUp,
  onMoveDown,
  renderItem,
  addButtonLabel = 'Add Row',
  maxItems,
}: AdminRepeaterProps<T>) {
  const canAdd = !maxItems || items.length < maxItems;

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <div>
          <h4 className="text-sm font-semibold text-slate-900">{title}</h4>
          {description && (
            <p className="text-xs text-slate-500 mt-0.5">{description}</p>
          )}
        </div>
        {canAdd && (
          <AdminButton
            type="button"
            variant="outline"
            size="sm"
            icon={<Plus className="w-3.5 h-3.5 text-[#159B76]" />}
            onClick={onAdd}
          >
            {addButtonLabel}
          </AdminButton>
        )}
      </div>

      {items.length === 0 ? (
        <div className="rounded-xl border border-dashed border-slate-200 p-6 text-center bg-slate-50/50">
          <p className="text-xs text-slate-400">No entries added yet.</p>
          {canAdd && (
            <button
              type="button"
              onClick={onAdd}
              className="mt-2 text-xs font-semibold text-[#159B76] hover:underline"
            >
              + {addButtonLabel}
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-2.5">
          {items.map((item, index) => (
            <div
              key={index}
              className="flex items-start gap-2.5 p-3.5 rounded-xl border border-slate-200 bg-slate-50/30 hover:border-slate-300 transition-colors"
            >
              <div className="flex-1">{renderItem(item, index)}</div>
              <div className="flex items-center gap-1 pt-1 flex-shrink-0">
                {onMoveUp && (
                  <button
                    type="button"
                    disabled={index === 0}
                    onClick={() => onMoveUp(index)}
                    className="p-1 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 disabled:opacity-30 disabled:pointer-events-none transition-colors"
                    title="Move up"
                  >
                    <ArrowUp className="w-3.5 h-3.5" />
                  </button>
                )}
                {onMoveDown && (
                  <button
                    type="button"
                    disabled={index === items.length - 1}
                    onClick={() => onMoveDown(index)}
                    className="p-1 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 disabled:opacity-30 disabled:pointer-events-none transition-colors"
                    title="Move down"
                  >
                    <ArrowDown className="w-3.5 h-3.5" />
                  </button>
                )}
                <button
                  type="button"
                  onClick={() => onRemove(index)}
                  className="p-1 rounded-lg text-red-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                  title="Remove row"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
