import React from 'react';
import clsx from 'clsx';
import PropTypes from 'prop-types';
import {
  Avatar,
  Box,
  Card,
  CardContent,
  Grid,
  Typography,
  colors,
  makeStyles,
  Link
} from '@material-ui/core';
import AllInclusiveIcon from '@material-ui/icons/AllInclusive';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100%'
  },
  avatarInactive: {
    backgroundColor: colors.red[600],
    height: 56,
    width: 56
  },
  avatarActive: {
    backgroundColor: colors.green[600],
    height: 56,
    width: 56
  },
  differenceIcon: {
    color: colors.red[900]
  },
  differenceValue: {
    color: colors.red[900],
    marginRight: theme.spacing(1)
  },
  isInactive: {
    color: colors.red[900],
  },
  isActive: {
    color: colors.green[900],
  },
  text: {
    color: colors.red[600]
  }
}));

const BasicLogging = ({ className, isActive, ...rest }) => {
  const classes = useStyles();
  return (
    <Card
      className={clsx(classes.root, className)}
      {...rest}
    >
      <Link href="settings" underline="none">
        <CardContent>
          <Grid
            container
            justify="space-between"
            spacing={3}
          >
            <Grid item>
              <Typography
                color="textSecondary"
                gutterBottom
                variant="h6"
              >
                Basic logging
              </Typography>
              <Typography
                className={isActive ? classes.isActive : classes.isInactive}
                variant="h3"
              >
                {isActive ? 'Active' : 'Not active'}
              </Typography>
            </Grid>
            <Grid item>
              <Avatar className={isActive ? classes.avatarActive : classes.avatarInactive}>
                <AllInclusiveIcon />
              </Avatar>
            </Grid>
          </Grid>
          <Box
            mt={2}
            display="flex"
            alignItems="center"
          >
            <Typography
              color="textSecondary"
              variant="caption"
            >
              1xxxx records logged
            </Typography>
          </Box>
        </CardContent>
      </Link>
    </Card>
  );
};

BasicLogging.propTypes = {
  className: PropTypes.string,
  isActive: PropTypes.bool
};

export default BasicLogging;
