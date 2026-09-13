import React from 'react';

interface AdminInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
  icon?: React.ReactNode;
}

export const AdminInput = React.forwardRef<HTMLInputElement, AdminInputProps>(
  ({ label, error, hint, icon, className = '', id, ...props }, ref) => {
    const inputId = id || (label ? label.toLowerCase().replace(/\s+/g, '-') : undefined);

    return (
      <div className="w-full">
        {label && (
          <label
            htmlFor={inputId}
            className="block text-xs font-semibold text-slate-700 mb-1.5"
          >
            {label}
            {props.required && <span className="text-red-500 ml-1">*</span>}
          </label>
        )}
        <div className="relative rounded-xl shadow-sm">
          {icon && (
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              {icon}
            </div>
          )}
          <input
            id={inputId}
            ref={ref}
            className={`block w-full rounded-xl border bg-white text-slate-900 text-sm px-3.5 py-2.5 placeholder:text-slate-400 focus:outline-none focus:ring-2 transition-all duration-150 ${
              icon ? 'pl-10' : ''
            } ${
              error
                ? 'border-red-300 focus:border-red-500 focus:ring-red-500/20 text-red-900'
                : 'border-slate-200 focus:border-[#159B76] focus:ring-[#159B76]/20'
            } ${className}`}
            {...props}
          />
        </div>
        {error && <p className="mt-1 text-xs text-red-600 font-medium">{error}</p>}
        {hint && !error && <p className="mt-1 text-xs text-slate-400">{hint}</p>}
      </div>
    );
  }
);
