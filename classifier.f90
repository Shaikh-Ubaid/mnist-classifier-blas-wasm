SUBROUTINE DGEMV(TRANS,M,N,ALPHA,A,LDA,X,INCX,BETA,Y,INCY)
    DOUBLE PRECISION ALPHA,BETA
    INTEGER INCX,INCY,LDA,M,N
    CHARACTER TRANS
    DOUBLE PRECISION A(LDA,*),X(*),Y(*)
    DOUBLE PRECISION ONE,ZERO
    PARAMETER (ONE=1.0D+0,ZERO=0.0D+0)
    DOUBLE PRECISION TEMP
    INTEGER I,INFO,IX,IY,J,JX,JY,KX,KY,LENX,LENY
    INTRINSIC MAX
    INFO = 0
    IF ((TRANS /= 'N') .AND. (TRANS /= 'T') .AND. (TRANS /= 'C')) THEN
        INFO = 1
    ELSE IF (M.LT.0) THEN
        INFO = 2
    ELSE IF (N.LT.0) THEN
        INFO = 3
    ELSE IF (LDA.LT.MAX(1,M)) THEN
        INFO = 6
    ELSE IF (INCX.EQ.0) THEN
        INFO = 8
    ELSE IF (INCY.EQ.0) THEN
        INFO = 11
    END IF
    IF (INFO.NE.0) THEN
        PRINT *, "DGEMV: Error occured, INFO ", INFO
        RETURN
    END IF
    IF ((M.EQ.0) .OR. (N.EQ.0) .OR. ((ALPHA.EQ.ZERO).AND. (BETA.EQ.ONE))) RETURN
    IF (TRANS == 'N') THEN
        LENX = N
        LENY = M
    ELSE
        LENX = M
        LENY = N
    END IF
    IF (INCX.GT.0) THEN
        KX = 1
    ELSE
        KX = 1 - (LENX-1)*INCX
    END IF
    IF (INCY.GT.0) THEN
        KY = 1
    ELSE
        KY = 1 - (LENY-1)*INCY
    END IF
    IF (BETA.NE.ONE) THEN
        IF (INCY.EQ.1) THEN
            IF (BETA.EQ.ZERO) THEN
                DO 10 I = 1,LENY
                    Y(I) = ZERO
10             CONTINUE
            ELSE
                DO 20 I = 1,LENY
                    Y(I) = BETA*Y(I)
20             CONTINUE
            END IF
        ELSE
            IY = KY
            IF (BETA.EQ.ZERO) THEN
                DO 30 I = 1,LENY
                    Y(IY) = ZERO
                    IY = IY + INCY
30             CONTINUE
            ELSE
                DO 40 I = 1,LENY
                    Y(IY) = BETA*Y(IY)
                    IY = IY + INCY
40             CONTINUE
            END IF
        END IF
    END IF
    IF (ALPHA.EQ.ZERO) RETURN
    IF (TRANS == 'N') THEN
        JX = KX
        IF (INCY.EQ.1) THEN
            DO 60 J = 1,N
                TEMP = ALPHA*X(JX)
                DO 50 I = 1,M
                    Y(I) = Y(I) + TEMP*A(I,J)
50             CONTINUE
                JX = JX + INCX
60         CONTINUE
        ELSE
            DO 80 J = 1,N
                TEMP = ALPHA*X(JX)
                IY = KY
                DO 70 I = 1,M
                    Y(IY) = Y(IY) + TEMP*A(I,J)
                    IY = IY + INCY
70             CONTINUE
                JX = JX + INCX
80         CONTINUE
        END IF
    ELSE
        JY = KY
        IF (INCX.EQ.1) THEN
            DO 100 J = 1,N
                TEMP = ZERO
                DO 90 I = 1,M
                    TEMP = TEMP + A(I,J)*X(I)
90             CONTINUE
                Y(JY) = Y(JY) + ALPHA*TEMP
                JY = JY + INCY
100         CONTINUE
        ELSE
            DO 120 J = 1,N
                TEMP = ZERO
                IX = KX
                DO 110 I = 1,M
                    TEMP = TEMP + A(I,J)*X(IX)
                    IX = IX + INCX
110             CONTINUE
                Y(JY) = Y(JY) + ALPHA*TEMP
                JY = JY + INCY
120         CONTINUE
        END IF
    END IF
    RETURN
END

SUBROUTINE classifier(weights, image, classify)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: image(28 * 28), weights(28 * 28, 512, 4)
    DOUBLE PRECISION, INTENT(OUT) :: classify(10)
    DOUBLE PRECISION :: A(28 * 28, 512), Y(512)

    A = weights(:, :, 1)
    Y = weights(1:512, 1, 3)
    call DGEMV('T', 28 * 28, 512, 1.0d0, A, 28 * 28, image, 1, 1.0d0, Y, 1)

    A(1:512, 1:10) = weights(1:512, 1:10, 2)
    Y = MAX(0.0d0, Y)
    classify = weights(1:10, 1, 4)
    call DGEMV('T', 512, 10, 1.0d0, A, 28 * 28, Y, 1, 1.0d0, classify, 1)
END
