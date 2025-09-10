import { useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Indicator from './indicator';
import { fetchNui } from '../../utils/fetchNui';
import { Box, createStyles } from '@mantine/core';
import type { GameDifficulty, SkillCheckProps } from '../../typings';

export const circleCircumference = 2 * 50 * Math.PI;

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 50,
  medium: 40,
  hard: 25,
};

const useStyles = createStyles((theme, params: { difficultyOffset: number }) => ({
  svg: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    r: 50,
    width: 500,
    height: 500,
  },
  track: {
    fill: 'transparent',
    stroke: 'url(#DowntownGradient)',
    strokeWidth: 14,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    filter: 'url(#Downtown)',
    opacity: 0.9,
    '@media (min-height: 1440px)': {
      strokeWidth: 10,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
    },
  },
  skillArea: {
    fill: 'transparent',
    stroke: 'url(#DowntownRedGradient)',
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - (Math.PI * 50 * params.difficultyOffset) / 180,
    filter: 'url(#Downtown)',
    strokeLinecap: 'square',
    '@media (min-height: 1440px)': {
      strokeWidth: 10,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - (Math.PI * 65 * params.difficultyOffset) / 180,
    },
  },
  indicator: {
    stroke: '#ffffffff',
    strokeWidth: 5,
    fill: 'transparent',
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - 3,
    filter: 'url(#Downtown)',
    strokeLinecap: 'butt',
    transition: 'stroke 0.2s',
    '@media (min-height: 1440px)': {
      strokeWidth: 18,
      r: 65,
      strokeDasharray: 2 * 65 * Math.PI,
      strokeDashoffset: 2 * 65 * Math.PI - 5,
    },
  },
  button: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: 'rgb(0 0 0 / 55%)',
    border: '2px solid #666666c2',
    width: 86,
    height: 86,
    textAlign: 'center',
    borderRadius: '50%',
    fontSize: 35,
    fontWeight: 100,
    color: '#e9e9e9ef',
    fontFamily: '"rdr"',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    boxShadow: 'inset 0 4px 8px rgba(0,0,0,0.9), 0 0 25px rgba(19, 19, 19, 1)',
    backdropFilter: 'blur(2x)',
    textShadow: '0 0 15px rgba(31, 31, 31, 0.53), 0 0 25px rgba(255,255,255,0.4)',
    '&::before': {
      content: '""',
      position: 'absolute',
      inset: 0,
      background: 'linear-gradient(to bottom right, rgba(220, 38, 38, 0.4), #00000000)',
      borderRadius: '50%',
      pointerEvents: 'none',
      zIndex: -1
    }
  },

  trackInner: {
    fill: 'transparent',
    stroke: '#0a0a0a',
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    opacity: 0.8,
  },
  concentricRings: {
    fill: 'transparent',
    stroke: '#333333',
    strokeWidth: 1,
    cx: 250,
    r: 57,
    cy: 250,
    opacity: 0.8,
  },
  concentricRingsSecondary: {
    fill: 'transparent',
    stroke: '#1a1a1a',
    strokeWidth: 2,
    cx: 250,
    r: 57,
    cy: 250,
    opacity: 0.9,
  },
  concentricRingsTertiary: {
    fill: 'transparent',
    stroke: '#666666',
    strokeWidth: 1,
    cx: 250,
    cy: 250,
    opacity: 0.7,
  },
  metalTexture: {
    fill: 'url(#metalBrush)',
    r: 61,
    cx: 250,
    filter: 'blur(5px)',
    cy: 250,
    opacity: 0.7,
    '@media (min-height: 1440px)': {
      width: 30,
      height: 30,
      fontSize: 22,
    },
  },
}));

const SkillCheck: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const dataRef = useRef<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] } | null>(null);
  const dataIndexRef = useRef<number>(0);
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    angle: 0,
    difficultyOffset: 50,
    difficulty: 'easy',
    key: 'e',
  });
  const { classes } = useStyles({ difficultyOffset: skillCheck.difficultyOffset });

  useNuiEvent('startSkillCheck', (data: { difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }) => {
    dataRef.current = data;
    dataIndexRef.current = 0;
    const gameData = Array.isArray(data.difficulty) ? data.difficulty[0] : data.difficulty;
    const offset = typeof gameData === 'object' ? gameData.areaSize : difficultyOffsets[gameData];
    const randomKey = data.inputs ? data.inputs[Math.floor(Math.random() * data.inputs.length)] : 'e';
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: gameData,
      keys: data.inputs?.map((input) => input.toLowerCase()),
      key: randomKey.toLowerCase(),
    });

    setVisible(true);
  });

  useNuiEvent('skillCheckCancel', () => {
    setVisible(false);
    fetchNui('skillCheckOver', false);
  });

  const handleComplete = (success: boolean) => {
    if (!dataRef.current) return;
    if (!success || !Array.isArray(dataRef.current.difficulty)) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    if (dataIndexRef.current >= dataRef.current.difficulty.length - 1) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    dataIndexRef.current++;
    const data = dataRef.current.difficulty[dataIndexRef.current];
    const key = dataRef.current.inputs
      ? dataRef.current.inputs[Math.floor(Math.random() * dataRef.current.inputs.length)]
      : 'e';
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck((prev) => ({
      ...prev,
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: data,
      key: key.toLowerCase(),
    }));
  };

  return (
    <>
      {visible && (
        <>
          <svg className={classes.svg}>
            <defs>
              <linearGradient id="DowntownGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#4a4a4a" />
                <stop offset="25%" stopColor="#2c2c2c" />
                <stop offset="50%" stopColor="#1a1a1a" />
                <stop offset="75%" stopColor="#2c2c2c" />
                <stop offset="100%" stopColor="#4a4a4a" />
              </linearGradient>
              <linearGradient id="DowntownRedGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stopColor="#4a0000" />
                <stop offset="30%" stopColor="#800000" />
                <stop offset="70%" stopColor="#b22222" />
                <stop offset="100%" stopColor="#660000" />
              </linearGradient>
              <filter id="Downtown">
                <feGaussianBlur stdDeviation="1" result="coloredBlur"/>
                <feMerge> 
                  <feMergeNode in="coloredBlur"/>
                  <feMergeNode in="SourceGraphic"/>
                </feMerge>
              </filter>
              <pattern id="metalBrush" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
                <rect width="20" height="20" fill="#1a1a1a" fillOpacity="0.8"/>
                <line x1="0" y1="5" x2="20" y2="5" stroke="#2c2c2c" strokeWidth="0.5"/>
                <line x1="0" y1="10" x2="20" y2="10" stroke="#333" strokeWidth="0.3"/>
                <line x1="0" y1="15" x2="20" y2="15" stroke="#2c2c2c" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <image
              href="https://cdn.downtownrp.com.br/images/logos/logo.png"
              x="205"
              y="205"
              width="90"
              height="90"
              preserveAspectRatio="xMidYMid slice"
            />

            <circle className={classes.metalTexture} />
            <circle className={classes.concentricRings} r="62" />
            <circle className={classes.concentricRingsSecondary} r="58" />
            <circle className={classes.concentricRingsTertiary} r="54" />
            <circle className={classes.track} />
            <circle className={classes.trackInner} />

            <circle
              transform={`rotate(${skillCheck.angle}, 250, 250)`}
              className={classes.skillArea}
            />
            <Indicator
              angle={skillCheck.angle}
              offset={skillCheck.difficultyOffset}
              multiplier={
                skillCheck.difficulty === 'easy'
                  ? 1.0
                  : skillCheck.difficulty === 'medium'
                  ? 1.5
                  : skillCheck.difficulty === 'hard'
                  ? 1.75
                  : skillCheck.difficulty.speedMultiplier
              }
              handleComplete={handleComplete}
              className={classes.indicator}
              skillCheck={skillCheck}
            />
          </svg>
          <Box className={classes.button}>{skillCheck.key.toUpperCase()}</Box>
        </>
      )}
    </>
  );
};

export default SkillCheck;
