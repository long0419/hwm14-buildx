program hwm14_cli
    use hwm_interface           ! 你仓库已有接口模块
    implicit none

    real(8) :: glat, glon, alt_km
    integer :: year, doy
    real(8) :: sec
    real(8) :: stl
    real(8) :: f107a, f107, ap
    integer :: iyd
    real(8) :: w(2)

    character(len=64) :: arg

    if (command_argument_count() < 6) then
        print *, "Usage: hwm14_cli <lat> <lon> <alt_km> <year> <doy> <ut_seconds>"
        stop 1
    end if

    call get_command_argument(1, arg); read(arg, *) glat
    call get_command_argument(2, arg); read(arg, *) glon
    call get_command_argument(3, arg); read(arg, *) alt_km
    call get_command_argument(4, arg); read(arg, *) year
    call get_command_argument(5, arg); read(arg, *) doy
    call get_command_argument(6, arg); read(arg, *) sec

    ! HWM14 要求: IYD = yyyy*1000 + doy
    iyd = year * 1000 + doy

    ! 当地太阳时
    stl = mod(glon / 15.0d0 + sec / 3600.0d0, 24.0d0)

    ! F107 / AP — 模型要求但对结果影响小，可给固定值
    f107a = 150.0d0
    f107  = 150.0d0
    ap    = 4.0d0

    ! 调用接口
    call hwm14(iyd, sec, glat, glon, stl, f107a, f107, ap, w)

    ! 输出：Python 很容易解析
    write(*,'(A,2F12.6)') "Wmeridional Wzonal: ", w(1), w(2)

end program hwm14_cli
