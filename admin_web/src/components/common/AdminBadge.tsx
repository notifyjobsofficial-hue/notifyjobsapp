import React from 'react';

interface AdminBadgeProps {
  children: React.ReactNode;
  variant?: 'primary' | 'success' | 'warning' | 'danger' | 'slate' | 'info';
  size?: 'sm' | 'md';
  className?: string;
}

export const AdminBadge: React.FC<AdminBadgeProps> = ({
  children,
  variant = 'slate',
  size = 'md',
  className = '',
}) => {
  const sizeStyles = {
    sm: 'px-2 py-0.5 text-[11px] font-medium',
    md: 'px-2.5 py-1 text-xs font-semibold',
  };

  const variantStyles = {
    primary: 'bg-[#ECFDF5] text-[#117A5E] border border-[#159B76]/20',
    success: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
    warning: 'bg-amber-50 text-amber-800 border border-amber-200',
    danger: 'bg-red-50 text-red-700 border border-red-200',
    slate: 'bg-slate-100 text-slate-700 border border-slate-200',
    info: 'bg-blue-50 text-blue-700 border border-blue-200',
  };

  return (
    <span
      className={`inline-flex items-center rounded-full transition-colors ${sizeStyles[size]} ${variantStyles[variant]} ${className}`}
    >
      {children}
    </span>
  );
};
