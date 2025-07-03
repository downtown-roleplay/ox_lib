import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  container: {
    width: 400,
    height: 10,
    borderRadius: theme.radius.sm,
    overflow: 'hidden',
    backgroundColor: theme.colors.dark[8],
    clipPath: 'polygon(0.482505% 2.63537%, 6% 3.25874%, 12% 4.25874%, 18% 6.25874%, 24% 5.25874%, 30% 7.25874%, 36% 5.25874%, 42% 8.25874%, 48% 7.25874%, 54% 9.25874%, 60% 7.25874%, 66% 8.25874%, 72% 10.2587%, 78% 9.25874%, 84% 8.25874%, 90% 10.2587%, 95.397% 10.3576%, 98.3618% 15.2765%, 97.6734% 24.9636%, 98.3618% 34.3932%, 98.206% 50.625%, 98.603% 62.8833%, 98.2764% 77.2583%, 97% 88.0083%, 94% 92.2583%, 90% 96.2583%, 84% 98.2583%, 78% 97.2583%, 72% 95.2583%, 66% 97.2583%, 60% 99.2583%, 54% 98.2583%, 48% 96.2583%, 42% 98.2583%, 36% 99.2583%, 30% 97.2583%, 24% 94.2583%, 18% 95.2583%, 12% 94.2583%, 4.43181% 93.6689%, 3% 82.2583%, 2% 62.2583%, 2.63811% 44.3113%, 1.10488% 29.7219%, 1.7937% 18.4901%, 1.03496% 10.4106%, 0.361887% 3.20033%)',
  },
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
  },
  bar: {
    height: '100%',
    backgroundColor: theme.colors.gray[2],
  },
  labelWrapper: {
    position: 'absolute',
    display: 'flex',
    width: 350,
    height: 45,
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    maxWidth: 350,
    padding: 8,
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    fontSize: 20,
    color: theme.colors.gray[3],
    textShadow: theme.shadows.sm,
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Box className={classes.container}>
            <Box
              className={classes.bar}
              onAnimationEnd={() => setVisible(false)}
              sx={{
                animation: 'progress-bar linear',
                animationDuration: `${duration}ms`,
              }}
            >
              <Box className={classes.labelWrapper}>
                <Text className={classes.label}>{label}</Text>
              </Box>
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;
