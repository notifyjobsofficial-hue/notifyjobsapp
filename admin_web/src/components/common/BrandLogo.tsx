import React from 'react';

interface BrandLogoProps {
  className?: string;
  size?: number;
}

export const BrandLogo: React.FC<BrandLogoProps> = ({ className = 'w-9 h-9', size }) => {
  const style = size ? { width: size, height: size } : undefined;

  return (
    <div
      className={`relative flex items-center justify-center rounded-2xl overflow-hidden shadow-md shadow-[#0B2C5F]/20 flex-shrink-0 ${className}`}
      style={style}
    >
      <svg
        viewBox="0 0 100 100"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-full h-full"
      >
        {/* Navy Background */}
        <rect width="100" height="100" rx="22" fill="#0B2C5F" />
        
        {/* Subtle Brand Border Highlight */}
        <rect
          x="1"
          y="1"
          width="98"
          height="98"
          rx="21"
          stroke="#159B76"
          strokeOpacity="0.35"
          strokeWidth="2"
        />

        {/* Left N Pillar */}
        <rect x="26" y="28" width="9" height="44" rx="2.5" fill="#FFFFFF" />

        {/* Dynamic N Diagonal transitioning into Emerald Green */}
        <path d="M27 30L57 64V53L36 28H27V30Z" fill="#159B76" />

        {/* J Pillar & Loop */}
        <path
          d="M51 28H60V58C60 64.6 54.6 72 48 72C44 72 40.4 70 38.2 66.8L42.2 60.8C43.4 62.4 45.4 64 48 64C50.6 64 53 62 53 58V28H51Z"
          fill="#FFFFFF"
        />

        {/* Vibrant Orange Notification Spark / Dot */}
        <circle cx="70" cy="28" r="6.5" fill="#F59E0B" />
        <circle cx="68.5" cy="26.5" r="2" fill="#FFFFFF" fillOpacity="0.65" />
      </svg>
    </div>
  );
};

export default BrandLogo;
