import { Box, createStyles, Text } from '@mantine/core';
import React from 'react';

const useStyles = createStyles(() => ({
  container: {
    width: 410,
    height: 64,
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    backgroundColor: 'var(--dt-panel)',
    border: '1px solid var(--dt-hairline-strong)',
    borderBottom: 'none',
    borderTopLeftRadius: 2,
    borderTopRightRadius: 2,
    boxShadow: 'var(--dt-shadow-panel)',
    overflow: 'hidden',
  },
  heading: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    textAlign: 'center',
    fontSize: 20,
    fontWeight: 400,
    textTransform: 'uppercase',
    letterSpacing: '0.2em',
    color: 'var(--dt-text)',
    fontFamily: 'var(--dt-font-display)',
    textShadow: 'var(--dt-shadow-text)',
    padding: '0 16px',
  },
}));

const Header: React.FC<{ title: string }> = ({ title }) => {
  const { classes } = useStyles();

  return (
    <Box className={`${classes.container} dt-grain`}>
      <Text className={classes.heading}>{title}</Text>
      <div className="dt-rule" />
    </Box>
  );
};

export default React.memo(Header);
