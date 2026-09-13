import React from 'react';

interface Option {
  value: string;
  label: string;
}

interface AdminSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  options: Option[];
  error?: string;
  hint?: string;
}

export const AdminSelect = React.forwardRef<HTMLSelectElement, AdminSelectProps>(
  ({ label, options, error, hint, className = '', id, ...props }, ref) => {
    const selectId = id || (label ? label.toLowerCase().replace(/\s+/g, '-') : undefined);

    return (
      <div className="w-full">
        {label && (
          <label
            htmlFor={selectId}
            className="block text-xs font-semibold text-slate-700 mb-1.5"
          >
            {label}
            {props.required && <span className="text-red-500 ml-1">*</span>}
          </label>
        )}
        <select
          id={selectId}
          ref={ref}
          className={`block w-full rounded-xl border bg-white text-slate-900 text-sm px-3.5 py-2.5 focus:outline-none focus:ring-2 transition-all duration-150 cursor-pointer ${
            error
              ? 'border-red-300 focus:border-red-500 focus:ring-red-500/20 text-red-900'
              : 'border-slate-200 focus:border-[#159B76] focus:ring-[#159B76]/20'
          } ${className}`}
          {...props}
        >
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        {error && <p className="mt-1 text-xs text-red-600 font-medium">{error}</p>}
        {hint && !error && <p className="mt-1 text-xs text-slate-400">{hint}</p>}
      </div>
    );
  }
);
