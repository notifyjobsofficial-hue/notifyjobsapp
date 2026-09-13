import React from 'react';

interface AdminCardProps {
  title?: React.ReactNode;
  subtitle?: React.ReactNode;
  actions?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
  bodyClassName?: string;
  noPadding?: boolean;
}

export const AdminCard: React.FC<AdminCardProps> = ({
  title,
  subtitle,
  actions,
  children,
  className = '',
  bodyClassName = '',
  noPadding = false,
}) => {
  return (
    <div
      className={`bg-white rounded-2xl border border-slate-200/80 shadow-sm transition-all duration-200 hover:shadow-md/50 ${className}`}
    >
      {(title || actions) && (
        <div className="px-6 py-4 border-b border-slate-100 flex flex-wrap items-center justify-between gap-3">
          <div>
            {title && (
              <h3 className="text-base font-semibold text-slate-900 tracking-tight flex items-center gap-2">
                {title}
              </h3>
            )}
            {subtitle && (
              <p className="text-xs text-slate-500 mt-0.5">{subtitle}</p>
            )}
          </div>
          {actions && <div className="flex items-center gap-2">{actions}</div>}
        </div>
      )}
      <div className={`${noPadding ? '' : 'p-6'} ${bodyClassName}`}>
        {children}
      </div>
    </div>
  );
};
