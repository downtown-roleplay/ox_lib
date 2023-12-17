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
    // backgroundColor: theme.colors.dark[5],
    overflow: 'hidden',
    backgroundColor: 'rgba(0, 0, 0, 0.685)',
    clipPath: 'polygon(0% 0%, 0% 0%, 0% 0%, 0% 0%, 0% 0%, 30% 2%, 10% 1%, 30% 5%, 34% 1%, 39% 4%, 43% 5%, 50% 6%, 50% 7%, 53% 3%, 58% 6%, 61% 9%, 68% 4%, 74% 7%, 78% 9%, 84% 5%, 105% 9%, 95% 16%, 98% 19%, 99% 27%, 99% 3%, 96% 45%, 96% 50%, 97% 57%, 97% 61%, 96% 69%, 99% 82%, 95% 88%, 94% 93%, 97% 98%, 82% 99%, 81% 94%, 74% 91%, 61% 96%, 54% 97%, 50% 93%, 35% 99%, 34% 90%, 31% 90%, 15% 94%, 14% 93%, 9% 88%, 1% 90%, 6% 90%, 0% 57%, 2% 45%, 3% 43%, 2% 10%, 9% 20%, 2% 15%, 3% 13%)',
    textAlign: 'left',
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
    backgroundColor: 'rgba(255, 255,255, 0.865)',

    // backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
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
